class DummyChildModel < ApplicationRecord

  validates :title, presence: true, uniqueness: true

end
