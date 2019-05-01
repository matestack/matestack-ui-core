class DummyModel < ApplicationRecord

  validates :title, presence: true, uniqueness: true

end
