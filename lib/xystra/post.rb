module Xystra
  class Post
    attr_accessor :id, :parent_id, :type, :page_id, :reactions, :comments, :tags

    def initialize(id, type, page_id, parent_id)
      @id        = id
      @parent_id = parent_id
      @type      = type
      @page_id   = page_id
      @reactions = reactions
      @comments  = comments
      type == 'photo' ? @tags = tags : @tags = []
    end

    def reactions
      return @reactions if defined? @reactions # memoized reactions

      reactions = GraphApi.instance.get_connections(id, 'reactions')

      reactions.map do |reaction|
        Reaction.new(@page_id, reaction['id'], id, type, reaction['type'])
      end
    end

    def comments
      return @comments if defined? @comments # memoized comments

      comments = GraphApi.instance.get_connections(id, 'comments')

      comments.map do |comment|
        Comment.new(@page_id, comment['from']['id'], id, type)
      end
    end

    def tags
      return @tags if defined? @tags # memoized tags

      if parent_id
        tags = GraphApi.instance.get_object(parent_id, fields: 'with_tags')
      else
        tags = GraphApi.instance.get_object(id, fields: 'with_tags')
      end

      if tags && tags['with_tags'].present?
        tags['with_tags']['data'].map do |tag|
          Tag.new(@page_id, tag['id'], id, type, tag['name'])
        end
      end
    end

    def as_json(options = {})
      [reactions, comments, tags].flatten
    end

    def to_json(*options)
      as_json(*options).to_json(*options)
    end

    def as_csv
      [reactions, comments, tags]
    end

    def to_csv
      as_csv.to_csv
    end
  end
end
