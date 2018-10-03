// Author: Guilherme Amadio, Enrico Guiraud, Danilo Piparo CERN  2/2018

/*************************************************************************
 * Copyright (C) 1995-2016, Rene Brun and Fons Rademakers.               *
 * All rights reserved.                                                  *
 *                                                                       *
 * For the licensing terms see $ROOTSYS/LICENSE.                         *
 * For the list of contributors see $ROOTSYS/README/CREDITS.             *
 *************************************************************************/

#ifndef ROOT_RSNAPSHOTOPTIONS
#define ROOT_RSNAPSHOTOPTIONS

#include <Compression.h>
#include <ROOT/RStringView.hxx>
#include <string>

namespace ROOT {

namespace RDF {
/// A collection of options to steer the creation of the dataset on file
struct RSnapshotOptions {
   using ECAlgo = ::ROOT::ECompressionAlgorithm;
   RSnapshotOptions() = default;
   RSnapshotOptions(const RSnapshotOptions &) = default;
   RSnapshotOptions(RSnapshotOptions &&) = default;
   RSnapshotOptions(std::string_view mode, ECAlgo comprAlgo, int comprLevel, int autoFlush, int splitLevel, bool lazy)
      : fMode(mode), fCompressionAlgorithm(comprAlgo), fCompressionLevel{comprLevel}, fAutoFlush(autoFlush),
        fSplitLevel(splitLevel), fLazy(lazy)
   {
   }
   std::string fMode = "RECREATE";             //< Mode of creation of output file
   ECAlgo fCompressionAlgorithm = ROOT::kZLIB; //< Compression algorithm of output file
   int fCompressionLevel = 1;                  //< Compression level of output file
   int fAutoFlush = 0;                         //< AutoFlush value for output tree
   int fSplitLevel = 99;                       //< Split level of output tree
   bool fLazy = false;                        //< Delay the snapshot of the dataset
};
} // ns RDF
} // ns ROOT

#endif