require 'slack'
require 'faraday'

module Ruboty
  module Handlers
    class PiCameraUpload < Base
      def initialize
        Slack.configure do |config|
          config.token = ENV['SLACK_TOKEN']
        end
      end

      on(/camera/i, name: “pi_camera_upload”, description: "ラズパイの写真をアップロードします。")

      def pi_camera_upload
        Slack.chat_postMessage(
          channel: '#current_toyoshi_dev',
          text: 'test'
        )
      end
    end
  end
end
