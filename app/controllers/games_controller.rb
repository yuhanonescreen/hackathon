class GamesController < ApplicationController

  def index
binding.pry
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
  end
  
  def report
    
  end
  
end
