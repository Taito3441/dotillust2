class Illust < ApplicationRecord
    mount_uploader :image, ImageUploader
    
    belongs_to :user

    has_many :likes, dependent: :destroy
    has_many :liked_users, through: :likes, source: :user

    has_many :illust_tag_relations, dependent: :destroy
    has_many :tags, through: :illust_tag_relations, dependent: :destroy

    after_destroy :remove_unused_tags

    class RankedIllust
        attr_reader :illust, :rank, :monthly_likes

        def initialize(illust, rank, monthly_likes)
            @illust = illust
            @rank = rank
            @monthly_likes = monthly_likes
        end
    end
    
    def self.last_month
        from = Date.today.at_beginning_of_month
        to = Date.today.at_end_of_month

        Illust.joins(:likes)
                .where(likes: { created_at: from..to })
                .group(:id)
                .order(Arel.sql("count(*) desc"))
    end

    def save_tag(sent_tags)
        current_tags = self.tags.pluck(:tag_name) unless self.tags.nil?
        old_tags = current_tags - sent_tags
        new_tags = sent_tags - current_tags

        old_tags.each do |old|
            self.tags.delete Tag.find_by(tag_name: old)
        end
        
        new_tags.each do |new|
            new_illust_tag = Tag.find_or_create_by(tag_name: new)
            self.tags << new_illust_tag
        end
    end

    private 

    def remove_unused_tags  
        Tag.remove_unused
    end

end