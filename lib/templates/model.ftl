package ${packageName}.model<#if package??>.${package}</#if>

<#if primaryKeyMember??>
import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.Ignore
import androidx.room.PrimaryKey
import android.support.annotation.NonNull
</#if>
<#if parcelable>

import android.os.Parcel
import android.os.Parcelable
</#if>
<#if gson>

import com.google.gson.Gson
import com.google.gson.annotations.SerializedName
import com.google.gson.TypeAdapter
import com.google.gson.reflect.TypeToken
import com.google.gson.stream.JsonReader
import com.google.gson.stream.JsonToken
import com.google.gson.stream.JsonWriter
import com.google.gson.GsonBuilder
import ${packageName}.model.ModelAdapterFactory
</#if>
<#if importDate>

import java.util.Date
</#if>

<#list imports as import>
import ${import}
</#list>

<#if baseClass??>
import ${baseClass}
</#if>
<#if !imports?seq_contains("org.json.JSONObject")>

import org.json.JSONObject
</#if>

import java.io.IOException
import java.io.Serializable
  
/**
* AUTO-GENERATED CLASS.
* Make changes in <code>room.json</code> or use <code>PERSISTED SECTION</code> below
*/

<#if primaryKeyMember?? && !noTable>
@Entity(tableName = "${name?lower_case}")
</#if>
<#if open>open </#if>class ${name}<#if baseClassName??> : ${baseClassName}<#elseif parcelable> : </#if><#if parcelable><#if baseClassName??>, </#if>Parcelable</#if> {
<#list members as member>
    <#if member.localOnly>
    //LOCAL PROPERTY ONLY
    </#if>
    <#if member.primaryKey>
    @PrimaryKey<#if member.autoGenerate>(autoGenerate = true)</#if>
    @NonNull
    </#if>
    <#if member.ignored>
    @Ignore
    <#elseif primaryKeyMember??>
    @ColumnInfo(name = "${member.name}")
    </#if>
    <#if member.serializedName??>
    @SerializedName("${member.serializedName!member.name}")
    </#if>
    <#if member.noGson??>
    @Transient
    </#if>
    var ${member.memberName}: ${member.memberType?cap_first}<#if member.nullable>?</#if> = ${member.default}

</#list>

    constructor()
<#list constructors as constructor>

    <#if primaryKeyMember?? && !noTable>
    @Ignore
    </#if>
    constructor(${constructor.members[0].memberName}: ${constructor.members[0].memberType?cap_first}<#if constructor.members[0].nullable>?</#if><#list constructor.members[1..] as member>, ${member.memberName}: ${member.memberType?cap_first}<#if member.nullable>?</#if></#list>) {
<#list constructor.members as member>
        this.${member.memberName} = ${member.memberName}
</#list>
    }
</#list>
<#if parcelable>

    <#if primaryKeyMember?? && !noTable>
    @Ignore
    </#if>
    constructor(parcel: Parcel)<#if baseClassName??> : super(parcel)</#if> {
<#list members as member>
<#if member.type == "boolean">
        ${member.memberName} = parcel.readInt() == 1
<#elseif member.type == "enum">

        parcel.readString()?.let {
            ${member.memberName} = ${enumMap[member.class]}.valueOf(it)
        }

<#elseif member.type == "byte[]">

        val ${member.memberName}Length = parcel.readInt()
        if (${member.memberName}Length >= 0) {
            byte[] ${member.memberName} = new byte[${member.memberName}Length]
            parcel.readByteArray(${member.memberName})
            ${member.memberName} = ${member.memberName}
        }

<#elseif member.type == "Date">

        ${member.memberName}Time: long = parcel.readLong()
        if (${member.memberName}Time >= 0) {
            ${member.memberName} = Date(${member.memberName}Time)
        }

<#elseif member.type == "class">
    <#if member.parcelable??>
        ${member.memberName} = parcel.readParcelable(${modelMap[member.name + member.class]}::class.java.classLoader)
    <#elseif member.serializable??>
        ${member.memberName} = parcel.readSerializable() as ${modelMap[member.name + member.class]}<#if member.nullable>?</#if>
    </#if>
<#elseif member.type == "class[]">
    <#if member.parcelable??>
        ${member.memberName} = parcel.createTypedArrayList(${modelNameMap[member.class]}.CREATOR)
    <#elseif member.serializable??>

        val ${member.memberName}Count = parcel.readInt()
        if (${member.memberName}Count >= 0) {
            var ${member.memberName} = Array${modelMap[member.name + member.class]}()
            
            for (i in 0 until ${member.memberName}Count) {
                ${member.memberName}.add(parcel.readSerializable() as ${modelNameMap[member.class]})
            }

            this.${member.memberName} = ${member.memberName}
        }

    </#if>
<#else>
        ${member.memberName} = parcel.read${member.type?cap_first}()
</#if>
</#list>
    }

    override fun describeContents(): Int {
        return 0
    }

    override fun writeToParcel(parcel: Parcel, flags: Int) { 
<#if baseClassName??>
        super.writeToParcel(parcel, flags)
</#if>
<#list members as member>
<#if member.type == "boolean">
        parcel.writeInt(if (${member.memberName}) 1 else 0)
<#elseif member.type == "enum">
        parcel.writeString(if (${member.memberName} != null) (${member.memberName} as ${enumMap[member.class]}).name else null)
<#elseif member.type == "byte[]">

        if (${member.memberName} != null) {
            parcel.writeInt(${member.memberName}.length)
            parcel.writeByteArray(${member.memberName})
        } else {
            parcel.writeInt(-1)
        }

<#elseif member.type == "Date">

        if (${member.memberName} != null) {
            parcel.writeLong(${member.memberName}.getTime())
        } else {
            parcel.writeInt(-1)
        }

<#elseif member.type == "class">
    <#if member.parcelable??>
        parcel.writeParcelable(${member.memberName}, flags)
    <#elseif member.serializable??>
        parcel.writeSerializable(${member.memberName})
    </#if>
<#elseif member.type == "class[]">
    <#if member.parcelable??>
        parcel.writeTypedList(${member.memberName})
    <#elseif member.serializable??>

        if (${member.memberName} == null) {
            parcel.writeInt(-1)
        } else {
            parcel.writeInt(${member.memberName}!!.size)
        
            for (serializable in ${member.memberName}!!) {
                parcel.writeSerializable(serializable)
            }
        }

    </#if>
<#else>
        parcel.write${member.type?cap_first}(${member.memberName})
</#if>
</#list>
    }
</#if>

    // BEGIN PERSISTED SECTION - put custom methods here
${persistedSection}
    // END PERSISTED SECTION
<#if gson && !noTypeAdapter>

    class GsonTypeAdapter(gson: Gson) : TypeAdapter<${name}>() {
        <#list types as type>
        private val ${type.name?uncap_first}Adapter: TypeAdapter<${type.type}> = gson.getAdapter(<#if type.isList>object : TypeToken<${type.type}>(){}<#else>${type.name}::class.java</#if>)
        </#list>

        @Throws(IOException::class)
        override fun read(jsonReader: JsonReader): ${name}? {
            var json${name}: ${name}? = null

            if (jsonReader.peek() != JsonToken.NULL && jsonReader.peek() == JsonToken.BEGIN_OBJECT) {
                json${name} = ${name}()

                jsonReader.beginObject()

                while (jsonReader.hasNext()) {
                    val name = jsonReader.nextName()

                    if (jsonReader.peek() == JsonToken.NULL) {
                        jsonReader.skipValue()
                        continue
                    }
                
                    when (name) {
                    <#list baseMembers + members as member>
                        <#if !member.noGson>
                            <#if member.type == "enum">
                        "${member.serializedName!member.name}" -> {
                            val read = ${member.adapterType?uncap_first}Adapter.read(jsonReader)
                            if (read != null) {
                                json${name}.${member.memberName} = read
                            }
                        <#if member.default??>
                            else {
                                json${name}.${member.memberName} = ${member.default}
                            }
                        </#if>
                        }
                            <#else>
                        "${member.serializedName!member.name}" -> json${name}.${member.memberName} = ${member.adapterType?uncap_first}Adapter.read(jsonReader)
                            </#if>
                        </#if>
                    </#list>
                        else -> jsonReader.skipValue()
                    }
                }

                jsonReader.endObject()
                <#if customGson>

                json${name}.handleCustomGson(this)
                </#if>
            }

            return json${name}
        }

        @Throws(IOException::class)
        override fun write(jsonWriter: JsonWriter, ${name?uncap_first}: ${name}) {
            jsonWriter.beginObject()

    <#assign primitives = ['boolean', 'short', 'int', 'long', 'float', 'double']>
    <#list baseMembers + members as member>
        <#if !member.noGson>
            <#if primitives?seq_contains(member.type?lower_case)>
            jsonWriter.name("${member.serializedName!member.name}")
            ${member.adapterType?uncap_first}Adapter.write(jsonWriter, ${name?uncap_first}.${member.memberName})

            <#else> 
            ${name?uncap_first}.${member.memberName}?.let {
                jsonWriter.name("${member.serializedName!member.name}")
                ${member.adapterType?uncap_first}Adapter.write(jsonWriter, it)
            }
            
            </#if>
        </#if>
    </#list>     
            jsonWriter.endObject()
        }
    }
</#if>
<#if parcelable>

    companion object {
        @JvmField
        val CREATOR: Parcelable.Creator<${name}> = object : Parcelable.Creator<${name}> {
            override fun createFromParcel(parcel: Parcel) : ${name} {
                return ${name}(parcel)
            }

            override fun newArray(size: Int): Array<${name}?> {
                return arrayOfNulls(size)
            }
        }
    }
</#if>
}