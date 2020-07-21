class Demo::Pages::RailsViewAndPartial < Matestack::Ui::Page

  def response
    paragraph text: 'Rails View Component mit einer View'
    rails_view view: 'demo/header'
    paragraph text: 'Rails View Component mit einem Partial'
    rails_view partial: 'demo/header'
  end

end