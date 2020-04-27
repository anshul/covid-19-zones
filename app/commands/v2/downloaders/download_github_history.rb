# frozen_string_literal: true

module V2
  module Downloaders
    class DownloadGithubHistory < ::BaseCommand
      def self.perform_task(origin_code:)
        log "Starting download of #{origin_code}"
        cmd = new(origin_code: origin_code)
        cmd.call_with_transaction ? log("Done!", color: :green) : log("Failed: #{cmd.error_message}", color: :red)
      end

      attr_reader :origin, :origin_code, :response, :snapshot
      def initialize(origin_code:)
        @origin_code = origin_code.to_s
        @origin = ::V2::Origin.find_by(code: origin_code)
      end

      def run
        return add_error("Origin does not exist") if origin.blank?
        return add_error("Origin is #{origin.data_category}, expected github_history") unless origin.data_category == "github_history"
        return add_error("Origin does not have a valid source url") if origin.source_url.blank?
        return add_error("Origin does not have branches") if origin.details["branches"].blank?
        return add_error("Origin branches is not an array") unless origin.details["branches"].is_a?(Array)
        return add_error("Origin path is blank") if origin.details["path"].blank?

        origin.details["branches"].all? { |branch| fetch_commits(branch) } &&
          fetch_data &&
          create_snapshot_if_needed
      end

      def fetch_commits(branch)
        log "* Calling #{origin.source_url} #{branch} #{path}"

        commits = client.commits origin.source_url, path: path, sha: branch
        groups = commits.group_by { |c| c.commit.committer[:date].in_time_zone("Mumbai").to_date }
        groups.each do |date, arr|
          data[date] = arr.max_by { |c| c.commit.committer[:date] }
        end
        log "    > Got #{commits.length} commits for #{groups.keys.length} days."
      end

      def fetch_data
        log "* Fetching file from commits"
        data.sort.all? { |date, commit| fetch_commit(date, commit) }
      end

      def fetch_commit(date, commit)
        log "   > Fetching #{commit.sha}"
        content = client.contents origin.source_url, path: path, ref: commit.sha
        json[date] = JSON.parse(Base64.decode64(content.content))
      rescue JSON::ParserError => e
        add_error("Failed to parse json for #{date}, #{commit.sha} #{e.class} #{e.message}")
      end

      def path
        @path ||= origin.details["path"]
      end

      def data
        @data ||= {}
      end

      def json
        @json ||= {}
      end

      def client
        return @client if @client

        token = ENV["GITHUB_HISTORY_ACCESS_TOKEN"]
        token = nil unless token.to_s.length > 6
        @client = token ? ::Octokit::Client.new(access_token: token) : ::Octokit::Client.new
        @client.auto_paginate = true
        @client
      end

      def create_snapshot_if_needed
        return log("Data hasn't changed, skipping...") if ::V2::Snapshot.exists?(origin_code: origin_code, signature: signature)

        @snapshot = ::V2::Snapshot.new(
          origin_code:   origin_code,
          signature:     signature,
          data:          json,
          downloaded_at: t_start
        )

        return log("Failed to save snapshot, err: #{snapshot.errors.full_messages.to_sentence}", return_value: false) unless snapshot.save

        log("  > snapshot ##{@snapshot.id} created")
        true
      end

      def signature
        @signature ||= Digest::MD5.hexdigest(JSON.generate(json.deep_sort))
      end
    end
  end
end
