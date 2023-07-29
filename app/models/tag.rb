class Tag < ApplicationRecord
    has_many :illust_tag_relations, dependent: :destroy, foreign_key: 'tag_id'
    has_many :illusts, through: :illust_tag_relations

    def self.remove_unused
        Tag.all.each do |tag|
            if tag.illusts.count == 0
                tag.destroy
            end
        end
    end
end
