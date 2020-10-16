/********************************************************************
	filename: 	KIntersect.h
	file ext:	h
	author:		pk
	created:	2020/10/16 16:46:37
	purpose:
*********************************************************************/
#ifndef INTERSECT_H
#define INTERSECT_H

#include "KVector2.h"
//////////////////////////////////////////////////////////////////////////
// 2D intersect
#pragma region VEC2INTERSECT

void GetSegmentBoundingBox(const KVec2& v0, const KVec2& v1, KVec2& v2Min, KVec2& v2Max);

// @function Check if bounding boxes do intersect. If one bounding box touches the other, they do intersect.
// @param a first bounding box
// @param b second bounding box
// @return true if they intersect, else false.
BOOL TestSegmentBoundingBoxesIntersect(KVec2 aMin, KVec2 aMax, KVec2 bMin, KVec2 bMax);

// @function Checks if a point is on a line
// @param a line (interpreted as line, although given as segment)
// @param b point
// @return true if point is on line, else false
BOOL IsPointOnLine(KVec2 a0, KVec2 a1, KVec2 b);

// @function Check if a point is right of a line. If the point is on the line, it is not right of the line.
// @param a segment interpreted as a line
// @param b the point
// @return true if the point is right of the line, else false
BOOL IsPointRightOfLine(KVec2 a0, KVec2 a1, KVec2 b);

// @function Check if segment touches or crosses the line that is defined by segment.
// @param a segment interpreted as line
// @param b segment
// @return true if segment touches or crosses line, else false
BOOL TestSegmentTouchesOrCrossesLine(KVec2 a0, KVec2 a1, KVec2 b0, KVec2 b1);

// @function Check if segments intersect
// @param a first segment
// @param b second segment
// @return true if segments do intersect, else false
BOOL TestSegmentIntersect(KVec2 a0, KVec2 a1, KVec2 b0, KVec2 b1);
#pragma endregion

#endif
