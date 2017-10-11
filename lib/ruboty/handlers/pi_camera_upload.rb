require 'slack'
require 'faraday'
require 'tmpdir'

module Ruboty
  module Handlers
    class PiCameraUpload < Base
      on(/take photo|ワンタイムトークン/i, name: 'pi_camera_upload', description: "ラズパイの写真をアップロードします。")

      def pi_camera_upload(message)
        message.reply('撮影してくるから、ちょっと待ってね')

        Slack.configure do |config|
          config.token = ENV['SLACK_TOKEN']
        end

        Dir.mktmpdir do |dir|
          file_name = "#{dir}/image.png"
          system(`raspistill -w 480 -h 360 -o #{file_name}`)
          Slack.files_upload(
            filename: 'Raspberry Pi Camera Image',
            file: Faraday::UploadIO.new(file_name, 'image/png'),
            channels: "##{ENV['PI_CAMERA_UPLOAD_CHANNEL']}",
            initial_comment: ''
          )
        end
      end
    end
  end
end
