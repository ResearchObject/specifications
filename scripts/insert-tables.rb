# Script that will inject HTML descriptions of ontologies into a template document
require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'getopt/std'

$template="template.html"

BEHAVIOUR = {
  :debug => false,
  :verbose => false
}

opt = Getopt::Std.getopts("t:o:vd")

if opt["t"] then
  $template = opt["t"]
end
if opt["o"] then
  $out = opt["o"]
end
if opt["v"] then
  BEHAVIOUR[:verbose] = true
end
if opt["d"] then
  BEHAVIOUR[:debug] = true
end

LODE='http://www.essepuntato.it/lode/owlapi/'

# Where to find the ontologies
mappings = {
  'ro-model' => 'https://raw.github.com/wf4ever/ro/master/ro.owl',
  'wfdesc-model' => 'https://raw.github.com/wf4ever/ro/master/wfdesc.owl',
  'wfprov-model' => 'https://raw.github.com/wf4ever/ro/master/wfprov.owl'
}

template_doc = Nokogiri::HTML(open($template))

mappings.each do |model, url| 
  puts model if BEHAVIOUR[:debug]
  puts "#{LODE}#{url}" if BEHAVIOUR[:debug]
  doc = Nokogiri::HTML(open("#{LODE}#{url}"))
  puts doc if BEHAVIOUR[:debug]
  classes = doc.xpath("//div[@id='classes']")
  dataproperties = doc.xpath("//div[@id='dataproperties']")
  objectproperties = doc.xpath("//div[@id='objectproperties']")
  # Looks for <div id="[model]-documentation"> and injects the appropriate div from LODE
  template_doc.xpath("//div[@id='#{model}-documentation']").each do |div|
    if classes[0] then 
      div.add_child(classes[0])
    end
    if dataproperties[0] then 
      div.add_child(dataproperties[0])
    end
    if objectproperties[0] then 
      div.add_child(objectproperties[0])
    end
  end
end

if $out
  File.open($out,'w') do |f|
    f.puts template_doc.to_html
  end
else
  puts template_doc.to_html
end

