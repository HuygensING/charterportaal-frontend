#! /usr/bin/env python
# -*- coding: utf-8 -*-

"""
Created on Mon Oct 20 14:57:03 2014

@author: rik
"""
import shutil, os.path
import requests
import csv
import re
import json
from lxml import etree
from argparse import ArgumentParser

def getAllArchives(archiveFile, size):
    with open(archiveFile,'r') as f:
        for line in f:
            line = line.rstrip()
            getAllImages(line, size)

def getAllImages(archief, size):
    totalResultCount = 2
    curResults = 1
    while totalResultCount > curResults:
        [images, totalResultCount, curResults] = getImages(archief, curResults)
        print "      %s archives with images found" % len(images)
        downloadImages(images, size)
    print "done! :)"

def getImages(archief, startindex):
    """setup document from base parameters"""
    count = 500
    queryUrl = "http://www.gahetna.nl/beeldbank-api/opensearch/?q=%s&count=%s&startIndex=%s" % (archief, count, startindex)

    print "      Retrieving " + queryUrl
    doc = etree.parse(queryUrl)
    namespaces = {
        'ese': "http://www.europeana.eu/schemas/ese/",
        "memorix": "http://www.pictura-dp.nl/memorix/3.0",
        "opensearch": "http://a9.com/-/spec/opensearch/1.1/"
    }


    rss = doc.getroot()
    [channel] = rss.findall("channel")

    totalResultCount=int(channel.find("opensearch:totalResults", namespaces).text)
    startIndex=int(channel.find("opensearch:startIndex", namespaces).text)
    curResults=startIndex + len(channel.findall("item")) - 1 #startindex is included in the resultset as well

    images = {}
    for item in channel.findall("item"):
        # using a destructuring will crash the script if multiple matching elements are found
        [memorix] = item.findall("memorix:MEMORIX", namespaces)
        [names] = memorix.findall("field[@name='PhotoName']")
        [handles] = memorix.findall("field[@name='PhotoHandle']")
        handleValues = handles.findall("value")
        nameValues = names.findall("value")
        if len(nameValues) == 0:
            raise Exception("No name found!")
        if len(nameValues) != len(handleValues):
            raise Exception("Names and handles are not the same length!")
        imagevariants = {}
        images[nameValues[0].text] = imagevariants
        for i in range(len(handleValues)):
            data = {
                "id": extractId(handleValues[i].text),
                "name": nameValues[i].text,
                "images": {}
            }
            imagevariants[data["id"]] = data

        for shownBy in item.findall("ese:isShownBy", namespaces):
            url = shownBy.text
            if not url.startswith("http://"):
                raise Exception("not a http url: " + url)
            if not url.endswith(".jpg"):
                raise Exception("not a jpg file: " + url)
            uuid = url.split("/")[-1][0:-4]
            numXnum = re.compile("^[0-9]+x[0-9]+$")
            dimensionSegments = [segment for segment in url.split("/") if numXnum.match(segment)]
            if len(dimensionSegments) == 0:
                raise Exception("No segment containing the dimensions found in " + url)
            if len(dimensionSegments) > 1:
                raise Exception("Multiple segments containing dimensions found in " + url)
            [width, height] = dimensionSegments[0].split("x")
            if dimensionSegments[0] in imagevariants[uuid]["images"]:
                raise Exception("Multiple urls for the same dimensions? at least: " + imagevariants[uuid]["images"]["url"] + " and " + url)
            if uuid not in imagevariants:
                raise Exception("The image url " + url + "has not accompanying photoHandle/nameValue")
            imagevariants[uuid]["images"][dimensionSegments[0]] = {
                "url": url,
                "width": int(width),
                "height": int(height)
            }
    return [images, totalResultCount, curResults]

def extractId(handleUrl):
    if handleUrl.startswith("hdl://10648/"):
        return handleUrl[len("hdl://10648/"):]
    else:
        raise Exception("Unknow handle prefix")

def getSmallestImageLargerThan(size, images):
    #images always have the same aspect ratio so sorting by width and by height
    #gives the same order
    sortedImages = sorted(images.values(), key=lambda x: x["width"], reverse=True)
    prev = None
    for img in sortedImages:
        if img["width"] <= size or img["height"] <= size:
            return prev or img
        prev = img
    return prev

def downloadImages(imageStruct, min_width):
    """copy images from url to path; size is number"""
    for (charterName, charter) in imageStruct.items():
        for photo in charter.values():
            imgToDownload = getSmallestImageLargerThan(min_width, photo["images"])
            url = imgToDownload["url"]
            filename = photo["name"] + ".jpg"
            if os.path.isfile(filename):
                pass
                #print "      already downloaded" + filename
            else:
                r = requests.get(url)
                if r.status_code == 200:
                    with open(filename, 'wb') as f:
                        f.write(r.content)
                    print '      downloaded %s to %s' %(url, filename)
                else:
                    print "Could not download " + url


def main():
    """main"""
    parser = ArgumentParser(description="download National Archive images for specified archive",
                            prog=__file__)
    parser.add_argument("-f", "--archives", required=True,
                        help="""A file containing the archives to harvest from e.g.
                              with a line containing '1.01.02' for Staten Generaal""")
    parser.add_argument("-p", "--path", required=True,
                        help="""path to store images""")
    parser.add_argument("-w", "--min_width", required=True,
                      help="desired image width e.g. 300 500, 1280, 3000, the nearest greater size will be downloaded")

    print "Starting..."
    args = vars(parser.parse_args())
    archives = os.path.abspath(args["archives"])
    path = os.path.abspath(args["path"])
    min_width = int(args["min_width"])

    if not os.path.isdir(path):
        raise Exception(path + " is not a directory")
    os.chdir(path)

    getAllArchives(archives, min_width)

if __name__ == "__main__":
    main()
