  class User < ApplicationRecord
    attr_accessor :remember_token, :activation_token, :remember_me
    before_save :downcase_email
    before_create :create_activation_digest

    validates :name, presence: true, length: { maximum: 50 }
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    validates :email, presence: true, length: { maximum: 255 },
                      format:      { with: VALID_EMAIL_REGEX },
                      uniqueness:                          true
    has_secure_password
    validates :password, presence: true, length: { minimum: 6 }, allow_nil: true


    # 渡された文字列のハッシュ値を返す
    def User.digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                    BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end
    
    # remember_digest用ランダムな記憶トークンを返す
    def User.new_token
      SecureRandom.urlsafe_base64
    end

    # 永続的セッションのためハッシュ化したトークンをデータベースに記憶する
    def remember
      self.remember_token = User.new_token
      self.update_attribute(:remember_digest, User.digest(self.remember_token))
      self.remember_digest #ユーザーインスタンスのremember_digestを返す
    end
    

    # セッションハイジャック防止のためにセッショントークンを返す
    def session_token
      remember_digest || remember
    end

    # 渡されたトークンがダイジェストと一致したらtrueを返す
    def authenticated?(attribute,token)
      digest = self.send("#{attribute}_digest")
      return false if digest.nil?
      #BCrypt::Password.new(digest) == token
      BCrypt::Password.new(digest).is_password?(token)
    end

    # ユーザーのログイン情報を破棄する
    def forget
      update_attribute(:remember_digest, nil)
    end

    def expired?
       Time.now < self.created_at + 10.minutes
    end
  
    def activate
      update_columns(activated: true, activated_at: Time.zone.now)
    end

    # 有効化用のメールを送信する
    def send_activation_email
      UserMailer.account_activation(self).deliver_now
    end

    private

      # メールアドレスをすべて小文字にする
      def downcase_email
        self.email = self.email.downcase
      end
      
      # 有効化トークンとダイジェストを作成および代入する
      def create_activation_digest
        self.activation_token  = User.new_token
        self.activation_digest = User.digest(activation_token)
      end

  end 
