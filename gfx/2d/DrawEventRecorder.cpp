/* -*- Mode: C++; tab-width: 20; indent-tabs-mode: nil; c-basic-offset: 2 -*-
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "DrawEventRecorder.h"
#include "PathRecording.h"
#include "RecordingTypes.h"

namespace mozilla {
namespace gfx {

using namespace std;

DrawEventRecorderPrivate::DrawEventRecorderPrivate() : mExternalFonts(false)
{
}

void
DrawEventRecorderFile::RecordEvent(const RecordedEvent &aEvent)
{
  WriteElement(mOutputStream, aEvent.mType);

  aEvent.RecordToStream(mOutputStream);

  Flush();
}

void
DrawEventRecorderMemory::RecordEvent(const RecordedEvent &aEvent)
{
  WriteElement(mOutputStream, aEvent.mType);

  aEvent.RecordToStream(mOutputStream);
}

DrawEventRecorderFile::DrawEventRecorderFile(const char *aFilename)
  : mOutputStream(aFilename, ofstream::binary)
{
  WriteHeader(mOutputStream);
}

DrawEventRecorderFile::~DrawEventRecorderFile()
{
  mOutputStream.close();
}

void
DrawEventRecorderFile::Flush()
{
  mOutputStream.flush();
}

bool
DrawEventRecorderFile::IsOpen()
{
  return mOutputStream.is_open();
}

void
DrawEventRecorderFile::OpenNew(const char *aFilename)
{
  MOZ_ASSERT(!mOutputStream.is_open());

  mOutputStream.open(aFilename, ofstream::binary);
  WriteHeader(mOutputStream);
}

void
DrawEventRecorderFile::Close()
{
  MOZ_ASSERT(mOutputStream.is_open());

  mOutputStream.close();
}

DrawEventRecorderMemory::DrawEventRecorderMemory()
{
  WriteHeader(mOutputStream);
}

DrawEventRecorderMemory::DrawEventRecorderMemory(const SerializeResourcesFn &aFn) :
  mSerializeCallback(aFn)
{
  mExternalFonts = true;
  WriteHeader(mOutputStream);
}


void
DrawEventRecorderMemory::Flush()
{
}

void
DrawEventRecorderMemory::FlushItem(IntRect aRect)
{
  DetatchResources();
  WriteElement(mIndex, mOutputStream.mLength);
  mSerializeCallback(mOutputStream, mUnscaledFonts);
  WriteElement(mIndex, mOutputStream.mLength);
  ClearResources();
}

void
DrawEventRecorderMemory::Finish()
{
  size_t indexOffset = mOutputStream.mLength;
  // write out the index
  mOutputStream.write(mIndex.mData, mIndex.mLength);
  mIndex = MemStream();
  // write out the offset of the Index to the end of the output stream
  WriteElement(mOutputStream, indexOffset);
  ClearResources();
}


size_t
DrawEventRecorderMemory::RecordingSize()
{
  return mOutputStream.mLength;
}

void
DrawEventRecorderMemory::WipeRecording()
{
  mOutputStream = MemStream();
  mIndex = MemStream();

  WriteHeader(mOutputStream);
}

} // namespace gfx
} // namespace mozilla
