{ modules, ... }: { imports = with modules; [ secrets ]; }
