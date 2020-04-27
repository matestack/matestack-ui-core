class DummyModel < ApplicationRecord

  validates :title, presence: true, uniqueness: true

  attr_accessor :file
  attr_accessor :files

end
