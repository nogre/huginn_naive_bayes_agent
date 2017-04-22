require 'huginn_agent'
require 'nbayes'

#HuginnAgent.load 'huginn_naive_bayes_agent/concerns/my_agent_concern'
HuginnAgent.register 'huginn_naive_bayes_agent/naive_bayes_agent'
