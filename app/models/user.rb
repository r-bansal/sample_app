class User < ActiveRecord::Base
  attr_accessor :password
  attr_accessible :name, :email, :password, :password_confirmation
  
  has_many :microposts, :dependent => :destroy
  has_many :relationships, :dependent => :destroy,
						   :foreign_key => "follower_id"
  has_many :reverse_relationships, :dependent => :destroy,
								   :foreign_ke => "followed_id",
								   :class_name => "Relationship"
  has_many: following, :through => :relationships, :source => :followed
  has_many: followers, :through => :reverse_relationships,
					   :source =>  :follower
  
  
  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  validates :name,  :presence => true,
					:length => { :maximum => 50}
  validates :email, :presence => true,
					:format => { :with => email_regex },
					:uniqueness => { :case_sensitive => false}
  validates :password, :presence => true,
					   :confirmation => true,
					   :length => { :within => 6..40 }

  
  before_save :encrypt_password
  
  def has_password?(submitted_password)
    encrypted_password == encrypt(submitted_password)
  end
  
  def feed
	Micropost.where("user_id = ?", id)
  end
  
  def following?(followed)
    relationships.find_by_followed_id(followed)
  end
  
  def follow!(followed)
    relationships.create!(:followed_id => followed.id)
  end
  
  def follow!(followed)
    relationships.find_by_followed_id(followed).destroy
  end
  
  private
    
	class << self #clarifies, a class level method
		def authenticate(email, submitted_password) #self, class method
		  user = find_by_email(email) #do not need Self.
		  (user && user.has_password?(submitted_password)) ? user : nil
		  #return nil if user.nil?
		  #return user if user.has_password?(submitted_password)
		end
		
		def authenticate_with_salt(id, cookie_salt)
		  user = find_by_id(id)
		  (user && user.salt == cookie_salt) ? user : nil
		end
	end
	
	def encrypt_password
	  self.salt = make_salt if new_record?
	  self.encrypted_password = encrypt(self.password)
	end
	
	def encrypt(string)
	  secure_hash("#{salt}--#{string}") 
	end

	def secure_hash(string)
	  Digest::SHA2.hexdigest(string)
	end
	
	def make_salt
	  secure_hash("#{Time.now.utc}--#{password}")
	end 
end
