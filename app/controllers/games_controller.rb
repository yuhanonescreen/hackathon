class GamesController < ApplicationController

  def index

    user_id = cookies[:user_id]
    
    unless user_id
      ip = request.remote_ip
      user = User.where(:oauth_token=> ip).first
      unless user
        user = User.new
        user.oauth_token = ip
        user.name = ip
        user.save!
      end

      cookies[:user_id] = user.id
    end

    @game = Game.first(:order => 'id desc')

    if( @game)
      @time_passed = Time.now.to_i - @game.created_at.to_i
      if( @time_passed < @game.duration + 10 ) 
        # play the f
          @content_id = @game.content_id
          @created_at = @game.created_at.to_i
        return
      end
    end

    @content_id = 0
    @created_at = 0
    @time_passed = 0
    # TODO how to pick to video?

    Twitter.configure do |config|
      config.consumer_key = 'KJeCsg9oPlXd1FaPSokHQg'
      config.consumer_secret = "YNwIi3Y6dTlQecJUXmFNazUuvJ8DEfjjY5IBR3QpdDE"
    end
    
    response = Twitter.client.search("sport", :count=>100, :result_type => 'recent')
    @text = response.results.collect {|t| t.text}.flatten
  end
  
  def game
    index    
  end
  
  def create_game
    content_id = params[:content_id]

    @game = Game.new
    @game.content_id = content_id
    content = OneScreen::Internal::Content.find(content_id)
    asset_id = content.preview_asset_id
    asset = OneScreen::Internal::Asset.find(asset_id)
    @game.duration = asset.duration / 1000
    @game.save!
    
    render :json => {:status => "ok"}
  end
  
  def score
    content_id = params[:content_id]
    user_id = cookies[:user_id]
    
    users = User.where('id != ?', user_id).all
    user = User.find( user_id )
    users = Hash[ users.collect {|u| [u.name, u.score]}] 
    render :json => {:score=> user.score, :users => users}
  end

  def answer
    user_id = cookies[:user_id]
    
    answer = Answer.new
    answer.user_id = user_id
    answer.answer = params[:answer]
    answer.content_id = params[:content_id].to_i
    answer.save!
    my_answer = answer

    @game = Game.first(:order => 'id desc')
    similar_answers = Answer.where( :content_id => @game.content_id, :answer => params[:answer])
                  .where('user_id != ?', user_id)

    matched = false
    time_now = Time.now.to_i

    if(similar_answers.length > 0)
      my_answer.matched = 1
      similar_answers.each do |answer|
        user = User.find( answer.user_id )

        time_diff = time_now - answer.created_at.to_i
        if(time_diff < 10)
          user.score += 1
          user.save!
          matched = true
          answer.matched = 1
          answer.save!
        end
      end
      
      user = User.find( user_id )
      user.score += 1
      user.save!
    end
    render :json => {:matched =>  matched }
  end
  
  def login
    consumer_key = 'KJeCsg9oPlXd1FaPSokHQg'
    consumer_secret = "YNwIi3Y6dTlQecJUXmFNazUuvJ8DEfjjY5IBR3QpdDE"

    @consumer = OAuth::Consumer.new(consumer_key, consumer_secret, :site => "https://agree2")
    @request_token = @consumer.get_request_token
    session[:request_token] = @request_token
    redirect_to @request_token.authorize_url
  end
  
  def report
    user_id = cookies[:user_id]
    user = User.find( user_id )
    @my_score = user.score
  end
  
end
