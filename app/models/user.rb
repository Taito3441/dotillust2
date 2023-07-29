class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise  :database_authenticatable, :registerable,
          :recoverable, :rememberable, :validatable

  has_many :illusts, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_illusts, through: :likes, source: :illust

  def already_liked?(illust)
    self.likes.exists?(illust_id: illust.id)
  end

  has_many :illusts, dependent: :destroy
  validates :name, presence: true 
  validates :profile, length: { maximum: 200 } 

  attr_accessor :agreement
  validates :agreement, acceptance: { accept: '1' }

  
  has_many :following_relationships, foreign_key: "follower_id", class_name: "Relationship", dependent: :destroy
  has_many :followings, through: :following_relationships
  has_many :follower_relationships, foreign_key: "following_id", class_name: "Relationship", dependent: :destroy
  has_many :followers, through: :follower_relationships

  mount_uploader :image, ImageUploader

  def following?(other_user)
    following_relationships.find_by(following_id: other_user.id)
  end

  def follow!(other_user)
    following_relationships.create!(following_id: other_user.id)
  end

  def unfollow!(other_user)
    following_relationships.find_by(following_id: other_user.id).destroy
  end

  def admin?
    self.admin
  end
end