/**
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

/**
 * Types supported by TsFile. These types are used to define the data type of
 * each column/Timeseries in TsFile. It's stored as int8 on disk.
 * 
 */
enum DataType {
    BOOLEAN = 0,
    INT32 = 1,
    INT64 = 2,
    FLOAT = 3,
    DOUBLE = 4,
    TEXT = 5,
    VECTOR = 6,
    UNKNOWN = 7,
    TIMESTAMP = 8,
    DATE = 9,
    BLOB = 10,
    STRING = 11
}

enum CompressionType {
    UNCOMPRESSED = 0,
    SNAPPY = 1,
    GZIP = 2,
    LZ4 = 7,
    ZSTD = 8,
    LZMA2 = 9
}

enum Encoding {
    PLAIN = 0,
    DICTIONARY = 1,
    RLE = 2,
    DIFF = 3,
    TS_2DIFF = 4,
    BITMAP = 5,
    GORILLA_V1 = 6,
    REGULAR = 7,
    GORILLA = 8,
    ZIGZAG = 9,
    FREQ = 10, // deprecated
    CHIMP = 11,
    SPRINTZ = 12,
    RLBE = 13
}

struct BloomFilter {

}

struct String {
    1: required i32 length
    2: required binary value
}

struct DeviceId {
    1: required i32 segment_num 
    2: required list<String> segment_list
}

struct DeviceMetaIndexEntry {
    1: required DeviceId device_id
    2: required i64 offset
}

struct MeasurementMetaIndexEntry {
    1: required String measurement_name
    2: required i64 offset
}

enum MetaIndexNodeType {
    INTERNAL_DEVICE = 0,
    LEAF_DEVICE = 1,
    INTERNAL_MEASUREMENT = 2,
    LEAF_MEASUREMENT = 3
    INVALID_META_NODE_TYPE = 4
}

union MetaIndexEntry {
    1: DeviceMetaIndexEntry device_meta_index_entry
    2: MeasurementMetaIndexEntry measurement_meta_index_entry
}


struct MetaIndexNode {
    1: required String entry_name
    2: required i32 children_size
    3: required list<MetaIndexEntry> children
    4: required i64 end_offset 
    5: required MetaIndexNodeType node_type
}

struct ColumnSchema {
    1: required String column_name 
    2: required DataType data_type
    3: required Encoding Encoding
    4: required CompressionType compression_type
    5: required i32 properties_size
    5: required map<string, string> properties
}

struct TableSchema {
    1: required String table_name
    2: required i32 column_schema_size
    3: required 
}


struct FileMetaData {
    1: required i32 table_meta_data_index_node_map_size
    2: required list<MetaIndexNode> table_meta_data_index_node_map
    3: required i32 table_schema_size 


}




const string TSFILE_MAGIC = "TsFile";
