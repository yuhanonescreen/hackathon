class GamesController < ApplicationController

  def index
    @game = Game.first(:order => 'id desc')

    if( @game)
      time_passed = Time.now.to_i - @game.created_at.to_i
      if( time_passed < @game.duration + 20 ) 
        # play the game
        
        return
      end
    end

      # TODO how to pick to video?

    Twitter.configure do |config|
      config.consumer_key = 'KJeCsg9oPlXd1FaPSokHQg'
      config.consumer_secret = "YNwIi3Y6dTlQecJUXmFNazUuvJ8DEfjjY5IBR3QpdDE"
    end
    
    response = Twitter.client.search("sport", :count=>3, :result_type => 'recent')
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
  
  def game
    
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
    answer.sawe!
    
    # TODO: assign score
    
  end
  
  def report
    
  end
  
end
