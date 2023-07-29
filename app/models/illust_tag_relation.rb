class IllustTagRelation < ApplicationRecord

  belongs_to :illust
  belongs_to :tag

  validates :illust_id, presence: true
  validates :tag_id, presence: true
end
