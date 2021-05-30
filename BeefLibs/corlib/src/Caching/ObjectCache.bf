// This file contains portions of code released by Microsoft under the MIT license as part
// of an open-sourcing initiative in 2014 of the C# core libraries.
// The original source was submitted to https://github.com/Microsoft/referencesource

using System.Collections;
using System.Threading;

namespace System.Caching
{
	public enum DefaultCacheCapabilities
	{
		None = 0x0,
		InMemoryProvider = 0x1,
		OutOfProcessProvider = 0x2,
		CacheEntryChangeMonitors = 0x4,
		AbsoluteExpirations = 0x8,
		SlidingExpirations = 0x10,
		CacheEntryUpdateCallback = 0x20,
		CacheEntryRemovedCallback = 0x40,
		CacheRegions = 0x80
	}

	public abstract class ObjectCache : IEnumerable<(String key, Object value)>
	{
		private static IServiceProvider _host;

		public static readonly DateTimeOffset InfiniteAbsoluteExpiration = DateTimeOffset.MaxValue;
		public static readonly TimeSpan NoSlidingExpiration = TimeSpan.Zero;

		public static IServiceProvider Host
		{
			get { return _host; }

			set
			{
				Runtime.Assert(value != null);

				if (Interlocked.CompareExchange(ref _host, value, null) != null)
					Runtime.FatalError("Fatal error: The property has already been set, and can only be set once.");
			}
		}

		public abstract DefaultCacheCapabilities DefaultCacheCapabilities { get; }

		public abstract String Name { get; }

		//Default indexer property
		public abstract Object this[String key] { get; set; }

		public abstract CacheEntryChangeMonitor CreateCacheEntryChangeMonitor(IEnumerator<String> keys);

		public abstract IEnumerator<(String key, Object value)> GetEnumerator();

		//Existence check for a single item
		public abstract bool Contains(String key);

		//The Add overloads are for adding an item without requiring the existing item to be returned.  This was
		// requested for Velocity.
		public virtual bool Add(String key, Object value, DateTimeOffset absoluteExpiration) =>
			AddOrGetExisting(key, value, absoluteExpiration) == null;

		public virtual bool Add(CacheItem item, CacheItemPolicy policy) => AddOrGetExisting(item, policy) == null;

		public virtual bool Add(String key, Object value, CacheItemPolicy policy) =>
			AddOrGetExisting(key, value, policy) == null;

		public abstract Object AddOrGetExisting(String key, Object value, DateTimeOffset absoluteExpiration);

		public abstract CacheItem AddOrGetExisting(CacheItem value, CacheItemPolicy policy);

		public abstract Object AddOrGetExisting(String key, Object value, CacheItemPolicy policy);

		public abstract Object Get(String key);

		public abstract CacheItem GetCacheItem(String key);

		public abstract void Set(String key, Object value, DateTimeOffset absoluteExpiration);

		public abstract void Set(CacheItem item, CacheItemPolicy policy);

		public abstract void Set(String key, Object value, CacheItemPolicy policy);

		//Get multiple items by keys
		public abstract Dictionary<String, Object> GetValues(List<String> keys);

		public virtual Dictionary<String, Object> GetValues(params String[] keys) =>
			GetValues(scope List<String>(keys.GetEnumerator()));

		public abstract Object Remove(String key);

		public abstract int64 GetCount();
	}
}
