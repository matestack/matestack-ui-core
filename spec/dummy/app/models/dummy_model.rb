# used in specs

class DummyModel < ApplicationRecord

  validates :title, presence: true, uniqueness: true

  has_one_attached :file
  has_many_attached :files

  has_many :dummy_child_models, index_errors: true #https://bigbinary.com/blog/errors-can-be-indexed-with-nested-attrbutes-in-rails-5
  accepts_nested_attributes_for :dummy_child_models, allow_destroy: true
end
