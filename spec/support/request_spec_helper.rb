module RequestSpecHelper
    # Parse JSON response to ruby hash
    def json
      return JSON.parse(response.body)
    end
  end