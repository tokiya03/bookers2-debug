class BooksController < ApplicationController
  before_action :authenticate_user!

  def show
    @book = Book.find(params[:id])
    @new_book = Book.new
    @book_comment = BookComment.new
    @book_comments = @book.book_comments
    unless ViewCount.find_by(user_id: current_user.id, book_id: @book.id)
      current_user.view_counts.create(book_id: @book.id)
    end
  end

  def index
    @book = Book.new
    @book_comment = BookComment.new

    if params[:latest]
      @books = Book.latest
    elsif params[:old]
      @books= Book.old
    elsif params[:star_count]
      @books = Book.star_count
    else
      to = Time.current.at_end_of_day
      from = (to - 6.day).at_beginning_of_day
      @books = Book.includes(:favorited_users).
        sort {|a,b|
          b.favorited_users.includes(:favorites).where(created_at: from...to).size <=>
          a.favorited_users.includes(:favorites).where(created_at: from...to).size
        }
    end
  end

  def create
    @book = Book.new(book_params)
    @book.user_id = current_user.id
    if @book.save
      redirect_to book_path(@book), notice: "You have created book successfully."
    else
      @books = Book.all
      render "index"
    end
  end

  def edit
    @book = Book.find(params[:id])
    unless @book.user_id == current_user.id
      redirect_to books_path
    end
  end

  def update
    @book = Book.find(params[:id])
    unless @book.user_id == current_user.id
      redirect_to user_path(current_user.id)
    end

    if @book.update(book_params)
      redirect_to book_path(@book.id), notice: "You have updated book successfully."
    else
      render "edit"
    end
  end

  def destroy
    book = Book.find(params[:id])
    if book.destroy
      redirect_to books_path
    else
      render :show
    end
  end

  private
    def book_params
      params.require(:book).permit(:title, :body, :star)
    end
end
