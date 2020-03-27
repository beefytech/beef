using System;
using System.Collections.Generic;

namespace System.Threading {
	public function void InvokeFunction();
	public function void ForFunction(int64 idx);

	public sealed class Parallel {
#if BF_PLATFORM_WINDOWS
		static extern void InvokeInternal(void* func1, int count);

		public static void Invoke(InvokeFunction[] funcs)
		{
		    InvokeInternal(funcs.CArray(), funcs.Count);	
		}

		static extern void ForInternal(int64 from, int64 to, void* func);

		public static void For(int64 from, int64 to, ForFunction func)
		{
			ForInternal(from, to, (void*)func);
		}

		static extern void ForeachInternal(void* arrOfPointers, int count, int32 elementSize, void* func);

		// TODO: Make this also available for Dictionary
		public static void Foreach<T>(Span<T> arr, function void(T item) func)
		{
			List<void*> lv=scope List<void*>();

			for(ref T i in ref arr){
			    lv.Add(&i);
			}

			ForeachInternal(lv.Ptr, arr.Length, sizeof(T), (void*)func);
		}
#endif
	}
}
