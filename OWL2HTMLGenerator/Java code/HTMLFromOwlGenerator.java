/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package htmlfromowlgenerator;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.StringWriter;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import org.restlet.representation.Representation;
import org.restlet.resource.ClientResource;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

/**
 *
 * @author Daniel Garijo
 */
public class HTMLFromOwlGenerator {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        //Get the argument for the input file, output files
        String input = null, outClasses="classes", outProps="props";
        for(int a =0; a<args.length;a++){
            if(args[a].equals("-uri")){
                input = args[a+1];
            }else if(args[a].equals("-c")){
                outClasses = args[a+1];
            }else if(args[a].equals("-p")){
                outProps = args[a+1];
            }
        }
        if(input == null){
            System.out.println("Usage: java -jar HTMLFromOwlGenerator.jar -uri URI -c ClassesOutputFileName -p PropertiesOutputFileName");
            return;
        }
        //HTTP GET to the LODE servers
        ClientResource resource = new ClientResource("http://www.essepuntato.it/lode/owlapi/"+input);        
        // Send the HTTP GET request
        System.out.println("Querying LODE services for the HTML generation...");
        resource.get();            
        if (resource.getStatus().isSuccess()) {
            System.out.println("Generating HTML files "+outClasses+".html and "+outProps+".html ...");
            try {
                Representation r = resource.getResponseEntity();
                DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
                DocumentBuilder db = dbf.newDocumentBuilder();                    
                Document doc = db.parse(r.getStream());
                FileWriter fstreamC = new FileWriter(outClasses+".html");
                FileWriter fstreamP = new FileWriter(outProps+".html");
                BufferedWriter outC = new BufferedWriter(fstreamC);
                BufferedWriter outP = new BufferedWriter(fstreamP);

                NodeList c = doc.getElementsByTagName("div");
                for(int i = 0; i<c.getLength();i++){
                    String attrID = c.item(i).getAttributes().item(0).getTextContent();
                    if(attrID.equals("classes")){
                        outC.write("\n\n\n\n<!-- This is the html code for the classes list -->\n\n\n\n");
                        outC.write(getTermList(c.item(i)));
                        outC.write("\n\n\n\n<!-- This is the html code for the classes -->\n\n\n\n");
                        outC.write(nodeToString(c.item(i)));
                    }
                    else if(attrID.equals("objectproperties")){
                        outP.write("\n\n\n\n<!-- This is the html code for the property list -->\n\n\n\n");
                        outP.write(getTermList(c.item(i)));
                        outP.write("\n\n\n\n<!-- This is the html code for the properties -->\n\n\n\n");
                        outP.write(nodeToString(c.item(i)));
                    }
                }
                outC.close();
                outP.close();
                System.out.println("Done!");
            } catch (Exception ex) {
                System.out.println("Exception interpreting the resource: "+ ex.getMessage());
            }

        }else{
           System.out.println("An unexpected status was returned: "
               + resource.getStatus());
        }
    }

public static String getTermList(Node n){
    NodeList divs = n.getChildNodes();
    for(int j = 0; j<divs.getLength(); j++){
        //System.out.println(divs.item(j).getNodeName());
        if(divs.item(j).getNodeName().equals("ul")){            
            return(nodeToString(divs.item(j)));
        }       
    }    
    return null;
}    
public static String nodeToString(Node n){
        try {
            TransformerFactory transfac = TransformerFactory.newInstance();
            Transformer trans = transfac.newTransformer();
            trans.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "yes");
            trans.setOutputProperty(OutputKeys.INDENT, "yes");
            StringWriter sw = new StringWriter();
            StreamResult result = new StreamResult(sw);
            DOMSource source = new DOMSource(n);
            trans.transform(source, result);
            return(sw.toString());
        }
        
        catch (Exception ex) {
            System.out.println("Error while writting to xml");
            return null;
        }
}
}
