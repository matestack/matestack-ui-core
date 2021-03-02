class Demo::SecondPage < Matestack::Ui::Page

  def response
    h1 'Second Page'
    transition path: root_path do
      button 'First Page'
    end
  end

end