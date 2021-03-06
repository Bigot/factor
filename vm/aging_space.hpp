namespace factor {

struct aging_space : bump_allocator<object> {
  object_start_map starts;

  aging_space(cell size, cell start)
      : bump_allocator<object>(size, start), starts(size, start) {}

  object* allot(cell size) {
    if (here + size > end)
      return NULL;

    object* obj = bump_allocator<object>::allot(size);
    starts.record_object_start_offset(obj);
    return obj;
  }
};

}
