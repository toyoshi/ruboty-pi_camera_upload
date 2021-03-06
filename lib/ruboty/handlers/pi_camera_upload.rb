require 'slack'
require 'faraday'
require 'tmpdir'

module Ruboty
  module Handlers
    class PiCameraUpload < Base
      on(
        /take photo|ワンタイムトークン/i,
        name: 'pi_camera_upload',
        description: 'ラズパイの写真をアップロードします。'
      )

      def pi_camera_upload(message)
        message.reply('撮影してくるから、ちょっと待ってね')

        Dir.mktmpdir do |dir|
          file_name = "#{dir}/image.png"

          begin
            system(`raspistill #{ENV['CAMERA_OPTIONS']} -o #{file_name}`)
          rescue
            message.reply('写真の撮影ができなかったよ')
            return
          end

          upload_photo(file_name)
        end
      end

      private

      def upload_photo(file_name)
        ::Slack.configure do |config|
          config.token = ENV['SLACK_TOKEN']
        end

        ::Slack.files_upload(
          filename: 'Raspberry Pi Camera Image.png',
          file: Faraday::UploadIO.new(file_name, 'image/png'),
          channels: channel_name,
          initial_comment: ''
        )
      end

      def channel_name
        @channel_name = "##{ENV['SLACK_ROOM']}"
      end
    end
  end
end
