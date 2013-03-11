#!/usr/bin/env python

import xml.etree.ElementTree as ET
import hashlib, json, sys, xml.dom.minidom

nodes = {}
edges = {}

for xml_file_name in sys.argv[1:]:
    tree = ET.parse(xml_file_name)
    root = tree.getroot()
    last_intervention = {}
    for sp in root.iter('sp'):
        if sp.attrib['ana'] == 'intervention':
            last_intervention = sp.attrib
            last_intervention['id_intervenant'] = hashlib.md5(sp.attrib['who'].encode('utf-8')).hexdigest()
            if last_intervention['id_intervenant'] not in nodes:
                nodes[last_intervention['id_intervenant']] = sp.attrib
                nodes[last_intervention['id_intervenant']]['size'] = 1.0
        if sp.attrib['ana'] == 'interruption' and last_intervention != {}:
            id_intervenant = hashlib.md5(sp.attrib['who'].encode('utf-8')).hexdigest()
            if id_intervenant not in nodes:
                nodes[id_intervenant] = sp.attrib
                nodes[id_intervenant]['size'] = 1.0
            if id_intervenant not in edges:
                edges[id_intervenant] = {}
                edges[id_intervenant][last_intervention['id_intervenant']] = 1.0
            elif last_intervention['id_intervenant'] not in edges[id_intervenant]:
                edges[id_intervenant][last_intervention['id_intervenant']] = 1.0
            else:
                edges[id_intervenant][last_intervention['id_intervenant']] += 0.3
                nodes[id_intervenant]['size'] += 0.3

#print json.dumps(nodes)

#sys.exit(0)
#print json.dumps(edges)

gexf = ET.Element('gexf')
gexf.set("xmlns", "http://www.gexf.net/1.2draft")
gexf.set("xmlns:viz","http://www.gexf.net/1.1draft/viz")
gexf.set("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance")
gexf.set("xsi:schemaLocation","http://www.gexf.net/1.2draft\nhttp://www.gexf.net/1.2draft/gexf.xsd")
gexf.set("version", "1.2")
graph = ET.SubElement(gexf,"graph")
graph.set('defaultedgetype', 'directed')
gexf_nodes = ET.SubElement(graph, "nodes")

bad_nodes = []
for key in nodes:
    if 'n' in nodes[key]:
        node = ET.SubElement(gexf_nodes,'node')
        node.set("id", key)
#        if nodes[key]['size'] > 50:
        node.set("label", nodes[key]['who'])
        viz_size =  ET.SubElement(node, 'viz:size')
        viz_size.set('value', str(nodes[key]['size']))
        if nodes[key]['n'] == 'GDR':
            viz_color = ET.SubElement(node, 'viz:color')
            viz_color.set('r', '255')
            viz_color.set('g', '0')
            viz_color.set('b', '0')
        if nodes[key]['n'] == 'RRDP':
            viz_color = ET.SubElement(node, 'viz:color')
            viz_color.set('r', '176')
            viz_color.set('g', '23')
            viz_color.set('b', '31')
        elif nodes[key]['n'] == 'SRC':
            viz_color = ET.SubElement(node, 'viz:color')
            viz_color.set('r', '255')
            viz_color.set('g', '181')
            viz_color.set('b', '197')
        elif nodes[key]['n'] == 'UMP':
            viz_color = ET.SubElement(node, 'viz:color')
            viz_color.set('r', '0')
            viz_color.set('g', '0')
            viz_color.set('b', '255')
        elif nodes[key]['n'] == 'UDI':
            viz_color = ET.SubElement(node, 'viz:color')
            viz_color.set('r', '173')
            viz_color.set('g', '216')
            viz_color.set('b', '230')
        elif nodes[key]['n'] == 'ECOLO':
            viz_color = ET.SubElement(node, 'viz:color')
            viz_color.set('r', '0')
            viz_color.set('g', '255')
            viz_color.set('b', '0')
    else:
        bad_nodes.append(key)



gexf_edges = ET.SubElement(graph, "edges")
i = 0
for source in edges:
    if source not in bad_nodes:
        for target in edges[source]:
            if target not in bad_nodes and target != source:
                edge = ET.SubElement(gexf_edges, "edge")
                edge.set("id", str(i))
                edge.set("source", source)
                edge.set("target", target)
                edge.set("weight", str(edges[source][target]))
                viz_size = ET.SubElement(edge, 'viz:size')
                viz_size.set("value", str(edges[source][target]))
                i += 1
        

xml = xml.dom.minidom.parseString(ET.tostring(gexf, encoding="utf-8", method="xml"))
print xml.toprettyxml(indent="  ", newl="\n", encoding="utf-8")
