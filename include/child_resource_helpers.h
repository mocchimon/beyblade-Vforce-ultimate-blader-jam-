#ifndef UBJ_CHILD_RESOURCE_HELPERS_H
#define UBJ_CHILD_RESOURCE_HELPERS_H

#include <stdint.h>

uint32_t ChildResource_SelectLayout(void *child,
                                    uint32_t arg1, uint32_t arg2);
uintptr_t ChildResource_HorizontalOffsetRegister(uint32_t mode);
uintptr_t ChildResource_VerticalOffsetRegister(uint32_t mode);
uintptr_t ChildResource_BackgroundControlRegister(uint32_t mode);

#endif
