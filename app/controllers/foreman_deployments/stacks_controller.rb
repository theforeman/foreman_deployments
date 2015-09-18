module ForemanDeployments
  class StacksController < ApplicationController
    include Foreman::Controller::AutoCompleteSearch
  end
end
