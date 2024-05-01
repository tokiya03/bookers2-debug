class SearchesController < ApplicationController
  before_action :authenticate_user!

  def search
    # ユーザーが選択した検索対象のモデルを@modelに代入
    @model = params[:model]
    # ユーザーが入力した検索ワードを@contentに代入
    @content = params[:content]
    # ユーザーが選択した検索方法を@methodに代入
    @method = params[:method]

    # 選択されたモデルがUserモデルの場合処理を実行
    if @model == "user"
      # 検索対象のUserモデルに対して、検索を実行して結果を@resultsに代入
      @results = User.search_for(@content, @method)
    else
      # 検索対象のBookモデルに対して、検索を実行して結果を@resultsに代入
      @results = Book.search_for(@content, @method)
    end
  end
end
