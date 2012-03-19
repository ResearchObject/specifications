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
    # Ideally h2 should be downgraded to h3 as the headings end up a
    # bit iffy.  This is done via some hacking, ignoring the first
    # child of the generated LODE code and then inserting an h3. Not ideal. 
    if classes[0] then 
      # Assumes that the first child is the <h2></h2>
      div.add_child("<h3>Classes</h3>")
      first = true
      classes[0].children.each do |child|
        if first then
          first = false
        else
          div.add_child(child)
        end
      end
    end
    if dataproperties[0] then 
      # Assumes that the first child is the <h2></h2>
      div.add_child("<h3>Data Properties</h3>")
      first = true
      dataproperties[0].children.each do |child|
        if first then
          first = false
        else
          div.add_child(child)
        end
      end
    end
    if objectproperties[0] then 
      # Assumes that the first child is the <h2></h2>
      div.add_child("<h3>Object Properties</h3>")
      first = true
      objectproperties[0].children.each do |child|
        if first then
          first = false
        else
          div.add_child(child)
        end
      end
    end
  end
end

# Where to find the examples
examples = {
  'wfdesc-model' => './examples/wfdescExample.html'
}

examples.each do |model, url| 
  puts model if BEHAVIOUR[:debug]
  puts "#{LODE}#{url}" if BEHAVIOUR[:debug]
  doc = Nokogiri::HTML(open("#{url}"))
  puts doc if BEHAVIOUR[:debug]
  example = doc.xpath("//div[@id='examples']")
  # Looks for <div id="[model]-model-examples"> and injects the appropriate div from LODE
  template_doc.xpath("//div[@id='#{model}-examples']").each do |div|
    if example[0] then 
      div.add_child(example[0])
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

