class AuthenticateUser
    def initialize(username, password, role)
      @username = username
      @password = password
      @role = role
    end
  
    # Service entry point
    def call
      JsonWebToken.encode(user_id: user.id) if user
    end
  
    private
  
    attr_reader :username, :password, :role
  
    # verify user credentials
    def user
      user = User.find_by(username: username)
      return user if user && user.authenticate(password)
      # raise Authentication error if credentials are invalid
      raise(ExceptionHandler::AuthenticationError, Message.invalid_credentials)
    end
  end