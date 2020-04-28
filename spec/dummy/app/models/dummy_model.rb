class DummyModel < ApplicationRecord

  validates :title, presence: true, uniqueness: true
  
  has_one_attached :file
  has_many_attached :files
end
