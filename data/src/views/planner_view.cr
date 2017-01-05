class PlannerView < BaseView
  def initialize(@blog : Tremolite::Blog, @url : String)
  end

  def title
    @blog.data_manager.not_nil!["planner.title"].as(String)
  end

  def content
    data = Hash(String, String).new
    data["header_img"] = @blog.data_manager.not_nil!["planner.backgrounds"].as(String)
    load_html("planner", data)
  end
end
