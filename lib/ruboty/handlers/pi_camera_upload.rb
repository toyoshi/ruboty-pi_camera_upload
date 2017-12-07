require 'slack'
require 'faraday'
require 'tmpdir'

module Ruboty
  module Handlers
    class PiCameraUpload < Base
      on(/take photo|ワンタイムトークン/i, name: 'pi_camera_upload', description: 'ラズパイの写真をアップロードします。')

      def pi_camera_upload(message)
        message.reply('撮影してくるから、ちょっと待ってね')

        channel_name = "##{ENV['SLACK_ROOM']}"

        Dir.mktmpdir do |dir|
          file_name = "#{dir}/image.png"

          begin
            system(`raspistill -rot 90 -t 500 -w 800 -h 800 -o #{file_name}`)
          rescue
            message.reply('写真の撮影ができなかったよ')
            return
          end

          upload_photo(channel_name, file_name)
        end
      end

      def upload_photo(channel_name, file_name)
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
    end
  end
end
