/********************************************************************
	filename: 	KIntersect.cpp
	file ext:	cpp
	author:		pk
	created:	2020/10/16 16:46:37
	purpose:
*********************************************************************/
#include "KIntersect.h"

using namespace std;

//////////////////////////////////////////////////////////////////////////
// 2D intersect
#pragma region VEC2INTERSECT

void GetSegmentBoundingBox(const KVec2& v0, const KVec2& v1, KVec2& v2Min, KVec2& v2Max) {
	if (v0.x < v1.x)
	{
		v2Min.x = v0.x;
		v2Max.x = v1.x;
	}
	else
	{
		v2Min.x = v1.x;
		v2Max.x = v0.x;
	}

	if (v0.y < v1.y)
	{
		v2Min.y = v0.y;
		v2Max.y = v1.y;
	}
	else
	{
		v2Min.y = v1.y;
		v2Max.y = v0.y;
	}
}


// @function Check if bounding boxes do intersect. If one bounding box touches the other, they do intersect.
// @param a first bounding box
// @param b second bounding box
// @return true if they intersect, else false.
BOOL TestSegmentBoundingBoxesIntersect(KVec2 aMin, KVec2 aMax, KVec2 bMin, KVec2 bMax) {
	return aMin.x <= bMax.x && aMax.x >= bMin.x &&
		aMin.y <= bMax.y && aMax.y >= bMin.y;
}



// @function Checks if a point is on a line
// @param a line (interpreted as line, although given as segment)
// @param b point
// @return true if point is on line, else false
BOOL IsPointOnLine(KVec2 a0, KVec2 a1, KVec2 b) 
{
	KVec2 v2LineA(a1.x - a0.x, a1.y - a0.y);
	KVec2 v2Tmp(b.x - a0.x, b.y - a0.y);
	double r = v2LineA.cross(v2Tmp);
	return abs(r) < 0.000001;
}

// @function Check if a point is right of a line. If the point is on the line, it is not right of the line.
// @param a segment interpreted as a line
// @param b the point
// @return true if the point is right of the line, else false
BOOL IsPointRightOfLine(KVec2 a0, KVec2 a1, KVec2 b)
{
	KVec2 v2LineA(a1.x - a0.x, a1.y - a0.y);
	KVec2 v2Tmp(b.x - a0.x, b.y - a0.y);
	return v2LineA.cross(v2Tmp) < 0;
}

// @function Check if segment touches or crosses the line that is defined by segment.
// @param a segment interpreted as line
// @param b segment
// @return true if segment touches or crosses line second, else false
BOOL TestSegmentTouchesOrCrossesLine(KVec2 a0, KVec2 a1, KVec2 b0, KVec2 b1)
{
	return IsPointOnLine(a0, a1, b0)
		|| IsPointOnLine(a0, a1, b1)
		|| (IsPointRightOfLine(a0, a1, b0) ^ IsPointRightOfLine(a0, a1, b1));
}

// @function Check if line segments intersect
// @param a first line segment
// @param b second line segment
// @return true if lines do intersect, else false
BOOL TestSegmentIntersect(KVec2 a0, KVec2 a1, KVec2 b0, KVec2 b1) {
	KVec2 v2MinA, v2MaxA, v2MinB, v2MaxB;
	GetSegmentBoundingBox(a0, a1, v2MinA, v2MaxA);
	GetSegmentBoundingBox(b0, b1, v2MinB, v2MaxB);

	return TestSegmentBoundingBoxesIntersect(v2MinA, v2MaxA, v2MinB, v2MaxB)
		&& TestSegmentTouchesOrCrossesLine(a0, a1, b0, b1)
		&& TestSegmentTouchesOrCrossesLine(b0, b1, b0, b1);
}

#pragma endregion VEC2INTERSECT