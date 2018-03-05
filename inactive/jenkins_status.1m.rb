#!/usr/bin/env ruby -w
require "rubygems"
require "json"
require "net/http"
require "openssl"

# Outware
USER="wei.sun@outware.com.au"
PASS="61659d316702b0776577f63d3020fc3d"
BASE_URL="https://ci.omdev.io"
JENKINS_API_JSON_URI="/api/json?tree=jobs[displayName,lastBuild[fullDisplayName,result,building,timestamp,estimatedDuration]]"

JOBS=[
] # If this array is empty, the script will attemp to check for all jobs currently displayed on the jenkins

STATUS_ICONS={
  "SUCCESS" 	=> "🍏 ",
  "BUILDING" 	=> "🛠 ",
  "ABORTED" 	=> "🚫 ",
  "FAILURE" 	=> "🍎 ",
  "NOT_BUILT" 	=> "❌ ",
  "UNSTABLE" 	=> "🌋 ",
}

def allJobs
  # Read job list from the url below and map them to a hash of name=>url pair
  urlString="#{BASE_URL}#{JENKINS_API_JSON_URI}"
  jsonFeed=jsonFromURL(urlString)
  jobHash={}
  if jsonFeed["HTTPResponseCode"]=="200"
    jobHash=Hash[jsonFeed]
  end
  return jobHash
end

def jsonFromURL urlString, limit = 10
  # Read json feed from the given url string
  raise ArgumentError, 'HTTP redirect too deep' if limit == 0
  uri=URI.parse(urlString)
  http=Net::HTTP.new(uri.host, uri.port)
  http.use_ssl=true
  http.verify_mode=OpenSSL::SSL::VERIFY_NONE
  request=Net::HTTP::Get.new(uri.request_uri)
  request.basic_auth("#{USER}", "#{PASS}")
  response=http.start() { |res| res.request(request) }
  case response
  when Net::HTTPSuccess then response
  when Net::HTTPRedirection then jsonFromURL(response['location'], limit - 1)
  else
    response.error!
  end
  jsonFeed={}
  code=response.code
  if code=="200"
    jsonFeed=JSON.parse(response.body)
  end
  jsonFeed["HTTPResponseCode"]=code
  return jsonFeed
end

def diffTime(time1, time2)
  # Get time difference from given two times, regardless of their order
  t1=time1 >= time2 ? time1 : time2
  t2=time1 < time2 ? time1 : time2
  return t1 - t2
end

def printJobStatus job
  jobName=job["displayName"];
  buildInfo=job["lastBuild"]
  lastBuild={}
  if buildInfo.nil?
    jobName=job["displayName"]
    lastBuild["result"]="NOT_BUILT"
  else
    lastBuild=Hash[buildInfo]
    jobName=lastBuild["fullDisplayName"]
  end

  if lastBuild["building"]
    estimatedDuration=lastBuild["estimatedDuration"]
    timeStamp=Time.at(lastBuild["timestamp"].to_f / 1000)
    timeDiff=diffTime(Time.now, timeStamp)
    percentage=(timeDiff.to_f * 1000/estimatedDuration.to_f) * 100
    if percentage.to_i >= 99.9
      percentage=99.9
    end
    resultString="#{STATUS_ICONS["BUILDING"]} #{jobName} - #{percentage.round(2)}%"
  else
    result=lastBuild["result"]
    resultString="#{STATUS_ICONS[result]} #{jobName}"
  end

  print("#{resultString}\n")
end

def isAllPassing jobs
  if jobs.nil?
    return false
  end
  passed = true
  jobs.each do | i |
    lastBuild=Hash[i["lastBuild"]]
    passed = !(lastBuild["result"]!="SUCCESS")
    if !passed
      break
    end
  end
  return passed
end

def printStatusIcons
  print("Symbols:\n")
  STATUS_ICONS.each do |k, v|
    print("\t#{v} => #{k}\n")
  end
end

def jobStatusMonitor
  # Get all jobs
  jobs=allJobs["jobs"]
  filteredJobs={}

  if JOBS.empty?
    filteredJobs=jobs
  else
    filteredJobs=JOBS.map { |e| jobs.find { |h| h["displayName"] == "#{e}" } }
  end

  if isAllPassing(filteredJobs)
    print("🍏  All passing!\n")
  else
    print("❓  Something going on!\a\n")
  end

  if filteredJobs.nil?
    print("Empty job list! \n")
  else
    filteredJobs.each do | i |
      printJobStatus(Hash[i])
    end
  end

  printStatusIcons
end

jobStatusMonitor
