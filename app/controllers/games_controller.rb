class GamesController < ApplicationController

  def index
    @game = Game.first(:order => 'id desc')

    if( @game)
      time_passed = Time.now.to_i - @game.created_at.to_i
      if( time_passed < @game.duration + 20 ) 
        # play the f
        
        return
      end
    end

    # TODO how to pick to video?

    Twitter.configure do |config|
      config.consumer_key = 'KJeCsg9oPlXd1FaPSokHQg'
      config.consumer_secret = "YNwIi3Y6dTlQecJUXmFNazUuvJ8DEfjjY5IBR3QpdDE"
    end
    
    response = Twitter.client.search("sport", :count=>100, :result_type => 'recent')
    @text = response.results.collect {|t| t.text}.flatten
      content_id = 5153210
      
      # create a new game  
      @game = Game.new
      @game.content_id = content_id
      content = OneScreen::Internal::Content.find(content_id)
      asset_id = content.preview_asset_id
      asset = OneScreen::Internal::Asset.find(asset_id)
      @game.duration = asset.duration / 1000
      @game.save!
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
  end
  
  def score
    id = params[:id]
    unless id
      render :json => nil
      return
    end
     
    user = User.find( id )
    score = user.score if user
    render :json => score
  end
  
  def login
    user = params[:user]
  end
  
  def answer
    user_id = params[:user_id]
    answer = params[:answer]
    answer = Answer::create( :user_id => user_id, :answer => answer )
    answer.save!

    @game = Game.first(:order => 'id desc')
    similar_answers = Answer.where( :content_id => @game.content_id, :answer => answer).where_not(user_id => user_id)
    if(similar_answers.length > 0)
      similar_answers.each do |answer|
        user = User.find( answer.user_id )
        user.score += 1
        user.save!
      end
      
      user = User.find( user_id )
      user.score += 1
      user.save!
    end
    render :json => {:status=>'ok'}
  end
  
  def report
    
  end
  
end
