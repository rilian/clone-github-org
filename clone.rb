require 'octokit'
require 'byebug'

ENV['TIMESTAMP'] = Time.now.to_i.to_s

def get_repos(user: nil, org: nil)
  client = Octokit::Client.new(access_token: ENV['TOKEN'])
  repos = user.nil? ? client.org_repositories(org, per_page: 1000) : client.repos(user, per_page: 1000)

  # Most recently pushed code goes first
  repos = repos.sort { |a, b| b[:pushed_at] <=> a[:pushed_at] }.map {|e| e[:full_name] }

  puts "Found #{repos.size} repos: #{repos.join(' ')}"

  repos
end

def process_repos(repos, obj)
  repos.each do |repo|
    repo_path = "#{obj}/#{ENV['TIMESTAMP']}/#{repo.gsub("#{obj}/", '')}"
    system("mkdir -p #{repo_path}")
    system("git clone https://#{ENV['TOKEN']}:x-oauth-basic@github.com/#{repo}.git #{repo_path}")
  end

  system("tar -zcvf #{obj}/#{obj.downcase}-#{ENV['TIMESTAMP']}.tar.gz #{obj}/#{ENV['TIMESTAMP']}")
  system("rm -rf #{obj}/#{ENV['TIMESTAMP']}")
end

ENV['ORGS'].to_s.split(',').map(&:strip).each { |o| process_repos(get_repos(org: o), o) }
ENV['USERS'].to_s.split(',').map(&:strip).each { |u| process_repos(get_repos(user: u), u) }
