module ForemanDeployments
  class DeploymentsController < ApplicationController
    include Foreman::Controller::AutoCompleteSearch
  end
end
