class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  validates :username, uniqueness: { case_sensitive: false },
                       presence: true
  validate :avatar_image_size

  has_many :posts, dependent: :destroy
  has_many :responses, dependent: :destroy
  has_many :likes
  has_many :liked_posts, through: :likes, source: :likeable, source_type: "Post"
  has_many :liked_responses, through: :likes, source: :likeable, source_type: "Response"

  include UserFollowing
  include TagFollowing
  mount_uploader :avatar, AvatarUploader

  def add_like_to(likeable_obj)
    likes.create(likeable: likeable_obj)
  end

  def remove_like_from(likeable_obj)
    likes.find_by(likeable: likeable_obj).destroy
  end

  def likes_post?(post)
    liked_post_ids.include?(post.id)
  end

  def likes_response?(response)
    liked_response_ids.include?(response.id)
  end

  private

    # Validates the size on an uploaded image.
    def avatar_image_size
      if avatar.size > 5.megabytes
        errors.add(:avatar, "should be less than 5MB")
      end
    end
end
