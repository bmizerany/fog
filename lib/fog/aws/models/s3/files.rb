module Fog
  module AWS
    class S3

      class Files < Fog::Collection

        attribute :delimiter,     'Delimiter'
        attribute :is_truncated,  'IsTruncated'
        attribute :marker,        'Marker'
        attribute :max_keys,      'MaxKeys'
        attribute :prefix,        'Prefix'

        model Fog::AWS::S3::File

        def all(options = {})
          merge_attributes(options)
          if @loaded
            clear
          end
          @loaded = true
          collection = directory.collection.get(
            directory.name,
            options
          )
          if collection
            self.replace(collection.files)
          else
            nil
          end
        end

        def directory
          @directory
        end

        def get(key, options = {}, &block)
          options = {
            'delimiter'   => @delimiter,
            'marker'      => @marker,
            'max-keys'    => @max_keys,
            'prefix'      => @prefix
          }.merge!(options)
          data = connection.get_object(directory.name, key, options, &block)
          file_data = {
            :body => data.body,
            :key  => key
          }
          for key, value in data.headers
            if ['Content-Length', 'Content-Type', 'ETag', 'Last-Modified'].include?(key)
              file_data[key] = value
            end
          end
          new(file_data)
        rescue Excon::Errors::NotFound
          nil
        end

        def get_url(key, expires)
          connection.get_object_url(directory.name, key, expires)
        end

        def head(key, options = {})
          data = connection.head_object(directory.name, key, options)
          file_data = {
            :key => key
          }
          for key, value in data.headers
            if ['Content-Length', 'Content-Type', 'ETag', 'Last-Modified'].include?(key)
              file_data[key] = value
            end
          end
          new(file_data)
        rescue Excon::Errors::NotFound
          nil
        end

        def new(attributes = {})
          super({ :directory => directory }.merge!(attributes))
        end

        private

        def directory=(new_directory)
          @directory = new_directory
        end

      end

    end
  end
end
