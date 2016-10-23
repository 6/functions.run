module ApplicationHelper
  def parent_layout(layout)
    @view_flow.set(:layout, output_buffer)
    self.output_buffer = render(file: "layouts/#{layout}")
  end

  def title(page_title)
    content_for(:title) { page_title }
  end

  def description(description)
    content_for(:description) { description }
  end
end
