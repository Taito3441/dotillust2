class IllustsController < ApplicationController
    before_action :authenticate_user!, only: [:new, :create]
    def top
        # 月間ランキング
        end_of_month = Date.today.end_of_month
        start_of_month = end_of_month.beginning_of_month

        monthly_likes_counts = Illust.where(created_at: start_of_month..end_of_month)
            .left_joins(:likes)
            .group(:id)
            .select('illusts.*, COUNT(likes.id) as count_likes')
            .order('count_likes DESC, illusts.created_at DESC')

        grouped_monthly_illusts = monthly_likes_counts.group_by { |illust| illust.count_likes }.sort.reverse.to_h

        @monthly_ranks = []
        rank = 1
        grouped_monthly_illusts.each do |count, illusts|
            next if count == 0
            illusts.each do |illust|
                monthly_likes = illust.likes.where(created_at: start_of_month..end_of_month).count
                @monthly_ranks << Illust::RankedIllust.new(illust, rank, monthly_likes)
            end
            rank += 1
            break if @monthly_ranks.size == 10
        end
        # 総合ランキング
        overall_likes_counts = Illust.left_joins(:likes)
            .group(:id)
            .select('illusts.*, COUNT(likes.id) as count_likes')
            .order('count_likes DESC, illusts.created_at DESC')

            grouped_overall_illusts = overall_likes_counts.group_by { |illust| illust.count_likes }.sort.reverse.to_h

            @ranks = []
            rank = 1
            grouped_overall_illusts.each do |count, illusts|
                next if count == 0
                illusts.each do |illust|
                    overall_likes = illust.likes.count
                    @ranks << Illust::RankedIllust.new(illust, rank, overall_likes)
                end
                rank += 1
                break if @ranks.size == 10
            end
    end

    def index
        order_type = params[:order] == 'asc' ? :asc : :desc

        if params[:search] != nil && params[:search] != ''
                #部分検索かつ複数検索
                illusts_title = Illust.where("titles LIKE ? ",'%' + params[:search] + '%').order(created_at: order_type)
                illusts_tag = Illust.includes(:tags).where("tags.tag_name LIKE ? ",'%' + params[:search] + '%').references(:tags).order(created_at: order_type)
                @illusts = Kaminari.paginate_array(illusts_title | illusts_tag).page(params[:page]).per(20)
            else
                @illusts = Illust.all.order(created_at: order_type)
                @illusts = @illusts.page(params[:page]).per(20)
        end
    end

    def new
        @illust = current_user.illusts.new 
    end



    def cre_index
        @illusts = Illust.all
    end


    def create
        @illust = current_user.illusts.new(illust_params)           
        tag_list = params[:illust][:tag_name].split(/\s+|　+/)  
        
        if @illust.save
            @illust.save_tag(tag_list)                                                           
            redirect_to illusts_path      
        else
            redirect_to new_illust_path       
        end
    end



    def show
        @illust = Illust.find(params[:id])

        @illust_tags = @illust.tags
    end

    def search
        @tags =Tag.all
        @tag = Tag.find(params[:tag_id])  # クリックしたタグを取得
        @illusts = @tag.illusts.all           # クリックしたタグに紐付けられた投稿を全て表示
    end



    def edit
        @illust = Illust.find(params[:id])
        @tag_list=@illust.tags.pluck(:tag_name).join(nil)
    end

    def weekly_rank
        @ranks = Illust.last_week
    end
    
    def destroy
        @illust = Illust.find(params[:id])
        if current_user == @illust.user || current_user.admin?
            @illust.destroy
            flash[:success] = 'Illustration deleted'
            redirect_to action: :index
        else
            flash[:alert] = 'You do not have permission to delete this illustration'
            redirect_to @illust
        end
    end
    
    def update
        illust = Illust.find(params[:id])
        tag_list = params[:illust][:tag_name].split(/\s+|　+/)  
        if illust.update(illust_params)
            

            old_relations = IllustTagRelation.where(illust_id: illust.id)
            old_relations.each do |relation|
                relation.delete
            end

            illust.save_tag(tag_list)
            redirect_to illust_path(illust.id), notice:'投稿完了しました:)'
    
        else
            redirect_to :action => "new"
        end
    end

    def draw
        @illusts = Illust.all
    end


    private
    def illust_params
        params.require(:illust).permit(:titles, :image, :pixels, tag_ids: [])
    end
    
end
