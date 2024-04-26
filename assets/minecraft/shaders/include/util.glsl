/*
=== COPYRIGHT NOTICE ===
This shader code is written by KabanFriends.

Do not re-distribute this code without express permission from KabanFriends.
Please see the included LICENSE file for more information.
*/

#define EPSILON 0.001

bool compfloat(float one, float two, float epsilon) {
    return abs(one - two) < epsilon;
}

bool compfloat(float one, float two) {
    return compfloat(one, two, EPSILON);
}
